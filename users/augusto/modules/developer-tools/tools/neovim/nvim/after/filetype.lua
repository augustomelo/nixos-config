vim.filetype.add {
  extension = {
    htmx = "html",
    hurl = "hurl",
  },
  filename = {
    ["Jenkinsfile"] = "groovy"
  },
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"] = "helm",
  },
}
