#!/usr/bin/env python3
"""Idempotently upsert Microsoft Remote Desktop (macOS) bookmarks, credential, and trust labels."""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
import uuid
from pathlib import Path
from typing import Any


ENT_BOOKMARK = 1
ENT_CREDENTIAL = 5
ENT_TRUST = 12


def uuid5(name: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_DNS, name)).upper()


def ensure_primary_max(conn: sqlite3.Connection, ent: int, pk: int) -> None:
    row = conn.execute(
        "SELECT Z_MAX FROM Z_PRIMARYKEY WHERE Z_ENT = ?", (ent,)
    ).fetchone()
    if row is None:
        raise RuntimeError(f"Z_PRIMARYKEY missing for Z_ENT={ent}")
    current = row[0] or 0
    if pk > current:
        conn.execute(
            "UPDATE Z_PRIMARYKEY SET Z_MAX = ? WHERE Z_ENT = ?", (pk, ent)
        )


def next_pk(conn: sqlite3.Connection, table: str) -> int:
    row = conn.execute(f"SELECT COALESCE(MAX(Z_PK), 0) + 1 FROM {table}").fetchone()
    return int(row[0])


def upsert_credential(
    conn: sqlite3.Connection, cred_id: str, username: str, friendly_name: str
) -> int:
    row = conn.execute(
        "SELECT Z_PK, Z_OPT FROM ZCREDENTIALENTITY WHERE ZID = ?", (cred_id,)
    ).fetchone()
    if row:
        pk, opt = int(row[0]), int(row[1] or 1)
        conn.execute(
            """
            UPDATE ZCREDENTIALENTITY
            SET Z_OPT = ?, ZNILPASSWORD = 0, ZFRIENDLYNAME = ?, ZUSERNAME = ?
            WHERE Z_PK = ?
            """,
            (opt + 1, friendly_name, username, pk),
        )
        return pk

    pk = next_pk(conn, "ZCREDENTIALENTITY")
    conn.execute(
        """
        INSERT INTO ZCREDENTIALENTITY (
            Z_PK, Z_ENT, Z_OPT, ZNILPASSWORD, ZFRIENDLYNAME, ZID, ZUSERNAME
        ) VALUES (?, ?, 1, 0, ?, ?, ?)
        """,
        (pk, ENT_CREDENTIAL, friendly_name, cred_id, username),
    )
    ensure_primary_max(conn, ENT_CREDENTIAL, pk)
    return pk


def upsert_bookmark(
    conn: sqlite3.Connection,
    bookmark_id: str,
    friendly_name: str,
    hostname: str,
    credential_pk: int,
) -> int:
    row = conn.execute(
        "SELECT Z_PK, Z_OPT FROM ZBOOKMARKENTITY WHERE ZID = ?", (bookmark_id,)
    ).fetchone()
    if row:
        pk, opt = int(row[0]), int(row[1] or 1)
        conn.execute(
            """
            UPDATE ZBOOKMARKENTITY
            SET Z_OPT = ?, ZFRIENDLYNAME = ?, ZHOSTNAME = ?, ZCREDENTIAL = ?
            WHERE Z_PK = ?
            """,
            (opt + 1, friendly_name, hostname, credential_pk, pk),
        )
        return pk

    pk = next_pk(conn, "ZBOOKMARKENTITY")
    conn.execute(
        """
        INSERT INTO ZBOOKMARKENTITY (
            Z_PK, Z_ENT, Z_OPT,
            ZADMINMODE, ZAUDIOCAPTUREENABLED, ZAUDIOPLAYBACKENUM,
            ZAUTORECONNECTENABLED, ZCAMERAREDIRECTIONENABLED, ZCOLORDEPTHENUM,
            ZCONNECTIONCOUNT, ZDYNAMICRESOLUTIONENABLED, ZENABLERETINA,
            ZFOLDERREDIRECTIONENABLED, ZINPUTMODEENUM, ZPASTEBOARDREDIRECTIONENABLED,
            ZPRINTERREDIRECTIONENABLED, ZSCREENTYPEALLMONITORS, ZSCREENTYPEENUMTYPE,
            ZSCREENTYPEHEIGHT, ZSCREENTYPERESOLUTIONTYPE, ZSCREENTYPESCALE,
            ZSCREENTYPEWIDTH, ZSMARTCARDREDIRECTIONENABLED, ZSWAPMOUSEBUTTON,
            ZUSEPUBLISHEDDESKTOPSETTINGS,
            ZBOOKMARKFOLDER, ZCREDENTIAL, ZGATEWAY, Z_FOK_BOOKMARKFOLDER,
            ZAUTHORINGTOOL, ZCREATIONSOURCEENUM, ZFRIENDLYNAME, ZHOSTNAME, ZID,
            ZRDPSTRING, ZFOLDERREDIRECTIONCOLLECTION, ZLASTCONNECTED, ZTHUMBNAILIMAGE
        ) VALUES (
            ?, ?, 1,
            0, 0, 0,
            1, 0, 2,
            0, 1, 1,
            0, 0, 1,
            0, 0, 0,
            0, 0, 0,
            0, 0, 0,
            0,
            NULL, ?, NULL, NULL,
            'homelab-ansible', 'Manual', ?, ?, ?,
            NULL, NULL, NULL, NULL
        )
        """,
        (pk, ENT_BOOKMARK, credential_pk, friendly_name, hostname, bookmark_id),
    )
    ensure_primary_max(conn, ENT_BOOKMARK, pk)
    return pk


def upsert_trust(conn: sqlite3.Connection, label: str, trust_type: int = 1) -> int:
    row = conn.execute(
        "SELECT Z_PK, Z_OPT FROM ZTRUSTENTITY WHERE ZLABEL = ?", (label,)
    ).fetchone()
    if row:
        pk, opt = int(row[0]), int(row[1] or 1)
        conn.execute(
            "UPDATE ZTRUSTENTITY SET Z_OPT = ?, ZTYPE = ? WHERE Z_PK = ?",
            (opt + 1, trust_type, pk),
        )
        return pk

    pk = next_pk(conn, "ZTRUSTENTITY")
    conn.execute(
        """
        INSERT INTO ZTRUSTENTITY (Z_PK, Z_ENT, Z_OPT, ZTYPE, ZLABEL)
        VALUES (?, ?, 1, ?, ?)
        """,
        (pk, ENT_TRUST, trust_type, label),
    )
    ensure_primary_max(conn, ENT_TRUST, pk)
    return pk


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", required=True)
    parser.add_argument("--credential-id", required=True)
    parser.add_argument("--username", required=True)
    parser.add_argument("--credential-friendly-name", default="joshc (homelab)")
    parser.add_argument(
        "--connections-json",
        required=True,
        help="JSON list of {name, hostname, bookmark_id}",
    )
    parser.add_argument(
        "--trust-labels-json",
        default="[]",
        help="JSON list of trust labels (cert CN / hostname / IP)",
    )
    args = parser.parse_args()

    db_path = Path(args.db)
    if not db_path.is_file():
        print(f"ERROR: MSRDC database not found: {db_path}", file=sys.stderr)
        return 2

    connections: list[dict[str, Any]] = json.loads(args.connections_json)
    trust_labels: list[str] = json.loads(args.trust_labels_json)

    conn = sqlite3.connect(str(db_path))
    try:
        conn.execute("BEGIN")
        cred_pk = upsert_credential(
            conn,
            args.credential_id,
            args.username,
            args.credential_friendly_name,
        )
        bookmark_pks = []
        for item in connections:
            bookmark_id = item.get("bookmark_id") or uuid5(
                f"homelab.rdp.bookmark.{item['name']}"
            )
            bookmark_pks.append(
                upsert_bookmark(
                    conn,
                    bookmark_id,
                    item["name"],
                    item["hostname"],
                    cred_pk,
                )
            )
        trust_pks = [upsert_trust(conn, label) for label in trust_labels if label]
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    print(
        json.dumps(
            {
                "credential_pk": cred_pk,
                "bookmark_pks": bookmark_pks,
                "trust_pks": trust_pks,
                "credential_id": args.credential_id,
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
