vim.filetype.add {
  extension = {
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
