return {
  "David-Kunz/gen.nvim",
  event = "VeryLazy",
  opts = {
    model = "ollama/llama3", -- Default model
    display_mode = "split",
    show_prompt = true,
    show_model = true,
    no_auto_close = false,
    api_key = "", -- leave blank for Ollama/LiteLLM
    endpoint = "http://10.0.0.42:4000/v1/chat/completions", -- LiteLLM proxy
  },
}
