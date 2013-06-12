use "list.eh"

type Source {
  name: String,
  version: String,
  author: String,
  maintainer: String,
  copyright: String,
  homepage: String,
  section: String,
  license: String,
  builddepends: List
}

type Binary {
  name: String,
  version: String,
  author: String,
  maintainer: String,
  copyright: String,
  homepage: String,
  license: String,
  section: String,
  summary: String,
  depends: List,
  files: String
}
