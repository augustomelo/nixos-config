vim.filetype.add {
  extension = {
    gotmpl = "gotmpl",
    htmx = "html",
    hurl = "hurl",
  },
  filename = {
    ["Jenkinsfile"] = "groovy"
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml.gotmpl"] = "helm",
    ["values.*%.ya?ml.gotmpl"] = "helm",
  },
}
