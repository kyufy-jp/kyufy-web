# LLM / embedding adapters for the mounted kyufy_core engine, switched by ENV so the
# demo never dies on stage (SPEC §4): the default is the deterministic Null adapters —
# boots and demos with zero credentials and zero network. Verdicts always come from the
# engine's rules; the LLM only writes grounded explanations.
#
#   KYUFY_LLM=null       (default) both Null adapters
#   KYUFY_LLM=anthropic  Claude explanations via ENV["KYUFY_ANTHROPIC_API_KEY"]
#   KYUFY_LLM=openai     OpenAI-compatible endpoint (OpenCode / local) via
#                        KYUFY_OPENAI_API_KEY / _BASE_URL / _MODEL
#
# Keys live in the environment only — never in any repo file.
KyufyCore.configure do |c|
  case ENV.fetch("KYUFY_LLM", "null")
  when "anthropic"
    c.llm_adapter = KyufyCore::LLM::AnthropicAdapter.new
  when "openai", "opencode"
    c.llm_adapter = KyufyCore::LLM::OpenAICompatibleAdapter.new
  else
    c.llm_adapter = KyufyCore::LLM::NullAdapter.new
  end

  # Anthropic has no embeddings API; real embeddings come from an OpenAI-compatible
  # endpoint when its key is present, otherwise the Null adapter (citations are curated
  # at ingestion, so retrieval quality only affects fallback evidence).
  c.embedding_adapter =
    if ENV["KYUFY_OPENAI_API_KEY"].present?
      KyufyCore::Embedding::OpenAICompatibleAdapter.new
    else
      KyufyCore::Embedding::NullAdapter.new(dim: c.embedding_dim)
    end
end
