/** Scoped to this runner: avoid multiagents 0.5.0's untracked GUI auto-launches.
 * The reusable operator explicitly starts/tracks the web dashboard instead.
 * Installed package files and other clients are not modified.
 */
import {join} from 'node:path';
const original=Bun.spawn.bind(Bun);
const pkg=process.env.MULTIAGENTS_PACKAGE_ROOT;
if(!pkg)throw Error('MULTIAGENTS_PACKAGE_ROOT required');
Bun.spawn=((...args:any[])=>{
 const command=Array.isArray(args[0])?args[0]:args[0]?.cmd;
 const web=command?.[1]===join(pkg,'dashboard/server.ts');
 const tui=command?.[0]==='osascript'&&command?.[2]?.includes(join(pkg,'cli.ts')+' dashboard ');
 if(web||tui){process.stderr.write('[managed-runtime] suppressed package dashboard auto-launch\n');return original([process.execPath,'-e',''],{stdout:'ignore',stderr:'ignore'});}
 return original(...args as Parameters<typeof Bun.spawn>);
}) as typeof Bun.spawn;
await import(process.env.MULTIAGENTS_GUARD_PATH!);
