#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"
require "pathname"
require "set"

VALID_FAMILIES = %w[
  vendor_docs
  sdk_api_context
  library_indexes
  operator_prompts
].freeze

VALID_COLLECTION_STRATEGIES = %w[
  firecrawl_scrape
  firecrawl_batch_scrape
  firecrawl_map_then_scrape
  firecrawl_search_then_scrape
  firecrawl_crawl_limited
  playwright_fallback
  fetch_fallback
].freeze

VALID_OUTPUT_MODES = %w[
  full_capture
  structured_summary
  index_record
  sdk_context_note
  operator_prompt
].freeze

DEFAULT_PROVENANCE_MARKERS = [
  "Source:",
  "Source URL:",
  "source_url:",
  "Collection-tool:",
  "Capture mode: full_capture"
].freeze

def fail_with(errors)
  errors.each { |error| warn "ERROR: #{error}" }
  exit 1
end

def ensure_hash(value, label, errors)
  return value if value.is_a?(Hash)

  errors << "#{label} must be a mapping"
  {}
end

def ensure_array(value, label, errors)
  return value if value.is_a?(Array)

  errors << "#{label} must be a list"
  []
end

spec_path = ARGV[0]
if spec_path.nil? || spec_path.empty?
  warn "Usage: ruby validate_entry_spec.rb /path/to/entry-spec.yml"
  exit 2
end

unless File.exist?(spec_path)
  warn "ERROR: spec file not found: #{spec_path}"
  exit 1
end

spec = YAML.load_file(spec_path)
errors = []

unless spec.is_a?(Hash)
  fail_with(["entry spec must parse to a mapping"])
end

required_top_level = %w[
  entry_id
  content_families
  library_targets
  source_urls
  required_outputs
  output_modes
  collection_strategy
  context7_required
  context7_topics
  asset_requirements
  allowed_summary_outputs
  validation_rules
]

required_top_level.each do |key|
  errors << "missing top-level key: #{key}" unless spec.key?(key)
end

fail_with(errors) unless errors.empty?

content_families = ensure_array(spec["content_families"], "content_families", errors)
library_targets = ensure_hash(spec["library_targets"], "library_targets", errors)
source_urls = ensure_array(spec["source_urls"], "source_urls", errors)
required_outputs = ensure_array(spec["required_outputs"], "required_outputs", errors)
output_modes = ensure_hash(spec["output_modes"], "output_modes", errors)
collection_strategy = ensure_hash(spec["collection_strategy"], "collection_strategy", errors)
context7_topics = ensure_array(spec["context7_topics"], "context7_topics", errors)
allowed_summary_outputs = ensure_array(spec["allowed_summary_outputs"], "allowed_summary_outputs", errors)
validation_rules = ensure_hash(spec["validation_rules"], "validation_rules", errors)

invalid_families = content_families - VALID_FAMILIES
errors << "invalid content_families: #{invalid_families.join(', ')}" unless invalid_families.empty?

content_families.each do |family|
  errors << "library_targets missing entry for #{family}" unless library_targets.key?(family)
end

primary_strategy = collection_strategy["primary"]
errors << "collection_strategy.primary is required" if primary_strategy.to_s.empty?
if primary_strategy && !VALID_COLLECTION_STRATEGIES.include?(primary_strategy)
  errors << "invalid collection_strategy.primary: #{primary_strategy}"
end

%w[discovery].each do |key|
  next unless collection_strategy[key]
  next if VALID_COLLECTION_STRATEGIES.include?(collection_strategy[key])

  errors << "invalid collection_strategy.#{key}: #{collection_strategy[key]}"
end

ensure_array(collection_strategy["fallback"], "collection_strategy.fallback", errors).each do |strategy|
  next if VALID_COLLECTION_STRATEGIES.include?(strategy)

  errors << "invalid collection_strategy fallback: #{strategy}"
end

live_collection_required =
  collection_strategy["live_collection_required"] || validation_rules["live_collection_required"]
if live_collection_required && !primary_strategy.to_s.start_with?("firecrawl_")
  errors << "live collection requires a Firecrawl primary strategy"
end

if spec["context7_required"] && context7_topics.empty?
  errors << "context7_required is true but context7_topics is empty"
end

source_map = {}
source_urls.each_with_index do |entry, index|
  source = ensure_hash(entry, "source_urls[#{index}]", errors)
  url = source["url"]
  maps_to = ensure_array(source["maps_to"], "source_urls[#{index}].maps_to", errors)
  errors << "source_urls[#{index}] missing url" if url.to_s.empty?
  errors << "source_urls[#{index}] must map to at least one output" if maps_to.empty?
  source_map[url] = maps_to if url
end

output_ids = Set.new
required_output_index = {}
required_outputs.each_with_index do |entry, index|
  output = ensure_hash(entry, "required_outputs[#{index}]", errors)
  output_id = output["id"]
  path = output["path"]
  family = output["content_family"]
  provenance_required = output.fetch("provenance_required", false)
  summary_allowed = output.fetch("summary_allowed", false)
  context7_output_topics = ensure_array(output["context7_topics"], "required_outputs[#{index}].context7_topics", errors)
  asset_paths = ensure_array(output["asset_paths"], "required_outputs[#{index}].asset_paths", errors)
  output_source_urls = ensure_array(output["source_urls"], "required_outputs[#{index}].source_urls", errors)

  errors << "required_outputs[#{index}] missing id" if output_id.to_s.empty?
  errors << "required_outputs[#{index}] missing path" if path.to_s.empty?
  errors << "required_outputs[#{index}] has invalid content_family #{family}" unless VALID_FAMILIES.include?(family)
  errors << "duplicate output id: #{output_id}" if output_id && output_ids.include?(output_id)

  output_ids << output_id if output_id
  required_output_index[output_id] = output if output_id

  if spec["context7_required"] && !output.key?("context7_topics")
    errors << "required output #{output_id} must record context7_topics when context7_required is true"
  end

  if family == "sdk_api_context" && context7_output_topics.empty?
    errors << "sdk_api_context output #{output_id} must declare at least one context7 topic"
  end

  if summary_allowed && !allowed_summary_outputs.include?(output_id)
    errors << "output #{output_id} allows summary but is not listed in allowed_summary_outputs"
  end

  if !summary_allowed && allowed_summary_outputs.include?(output_id)
    errors << "output #{output_id} is listed in allowed_summary_outputs but summary_allowed is false"
  end

  output_source_urls.each do |url|
    errors << "output #{output_id} references undeclared source URL #{url}" unless source_map.key?(url)
  end

  next if path.to_s.empty?

  unless File.exist?(path)
    errors << "required output missing on disk: #{path}"
    next
  end

  mode = output_modes[output_id]
  unless VALID_OUTPUT_MODES.include?(mode)
    errors << "output #{output_id} has invalid or missing output mode #{mode.inspect}"
    next
  end

  if provenance_required && File.file?(path)
    content = File.read(path)
    markers = validation_rules["full_capture_provenance_markers"] || DEFAULT_PROVENANCE_MARKERS
    if %w[full_capture sdk_context_note operator_prompt structured_summary].include?(mode)
      unless markers.any? { |marker| content.include?(marker) }
        errors << "output #{output_id} is missing provenance markers in #{path}"
      end
    end

    if mode == "full_capture"
      if content.include?("Capture mode: structured_summary")
        errors << "output #{output_id} is labeled structured_summary but declared full_capture"
      end
      if !content.include?("Capture mode: full_capture") &&
         !content.include?("Collection-tool:") &&
         !content.include?("Source:")
        errors << "output #{output_id} does not look like a full capture; add provenance header fields"
      end
    end
  end

  asset_paths.each do |asset_path|
    errors << "declared asset missing for #{output_id}: #{asset_path}" unless File.exist?(asset_path)
  end
end

output_modes.each do |output_id, mode|
  errors << "output_modes references undeclared output #{output_id}" unless output_ids.include?(output_id)
  errors << "invalid output mode #{mode} for #{output_id}" unless VALID_OUTPUT_MODES.include?(mode)
end

source_map.each do |url, maps_to|
  maps_to.each do |output_id|
    errors << "source URL #{url} maps to undeclared output #{output_id}" unless output_ids.include?(output_id)
  end
end

ensure_array(validation_rules["required_metadata_outputs"], "validation_rules.required_metadata_outputs", errors).each do |output_id|
  errors << "required metadata output missing from required_outputs: #{output_id}" unless output_ids.include?(output_id)
end

ensure_array(validation_rules["required_index_outputs"], "validation_rules.required_index_outputs", errors).each do |output_id|
  errors << "required index output missing from required_outputs: #{output_id}" unless output_ids.include?(output_id)
end

packet_readme = validation_rules["packet_readme"]
validator_pass_token = validation_rules["validator_pass_token"] || "AI_LIBRARY_ENTRY_VALIDATION_OK"

if packet_readme && File.exist?(packet_readme)
  packet_text = File.read(packet_readme)
  if packet_text.include?("lifecycle: implemented") && !packet_text.include?(validator_pass_token)
    errors << "packet README claims lifecycle: implemented without validator pass token #{validator_pass_token}"
  end
end

fail_with(errors) unless errors.empty?

puts validator_pass_token
