class CbmcViewer < Formula
  include Language::Python::Virtualenv
  desc "Scans the output of CBMC and produces a browsable summary of the results"
  homepage "https://github.com/awslabs/aws-viewer-for-cbmc"
  url "https://github.com/awslabs/aws-viewer-for-cbmc.git",
      tag:      "viewer-2.12",
      revision: "7e47db35d8fc36997c3feaa69189497e5f65660d"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/model-checking/cbmc-viewer/releases/download/viewer-2.12"
    sha256 cellar: :any_skip_relocation, big_sur:      "b717705457917d46dde231921e668c1c649bb64ee6f33a6a2e55de8234372e22"
    sha256 cellar: :any_skip_relocation, catalina:     "9418be981e8a37177bcd5707f5f3938fe6508ac889e115db6e861571bf5d4e68"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e1a1a85ec6a8edbbb74a9e565bc403e385f44af34f27612dca4cfe5dadba820a"
  end

  depends_on "cbmc" => :test
  depends_on "python@3.9"
  depends_on "universal-ctags"

  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/91/a5/429efc6246119e1e3fbf562c00187d04e83e54619249eb732bb423efa6c6/Jinja2-3.0.3.tar.gz"
    sha256 "611bb273cd68f3b993fabdc4064fc858c5b47a973cb5aa7999ec1ba405c87cd7"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/bf/10/ff66fea6d1788c458663a84d88787bae15d45daa16f6b3ef33322a51fc7e/MarkupSafe-2.0.1.tar.gz"
    sha256 "594c67807fb16238b30c44bdf74f36c02cdf22d1c8cda91ef8a0ed8dabf5620a"
  end

  resource "voluptuous" do
    url "https://files.pythonhosted.org/packages/c0/2c/ccbeb25364e3e0c5e4522f13d66e2fc639bb4d4ecdf73be0959552cbecb4/voluptuous-0.12.2.tar.gz"
    sha256 "4db1ac5079db9249820d49c891cb4660a6f8cae350491210abce741fabf56513"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"main.c").write <<~EOS
      #include <stdlib.h>

      static int global;

      int main() {
        int *ptr = malloc(sizeof(int));
        assert(global > 0);
        return 0;
      }
    EOS

    system "goto-cc", "-o", "main.goto", "main.c"
    (testpath/"cbmc.xml").write shell_output("cbmc main.goto --trace --xml-ui", 10)
    (testpath/"coverage.xml").write shell_output("cbmc main.goto --cover location --xml-ui")
    (testpath/"property.xml").write shell_output("cbmc main.goto --show-properties --xml-ui")
    system bin/"cbmc-viewer", "--goto", "main.goto",
                              "--result", "cbmc.xml",
                              "--coverage", "coverage.xml",
                              "--property", "property.xml",
                              "--srcdir", "."
    assert_predicate testpath/"report/html/index.html", :exist?
  end
end
