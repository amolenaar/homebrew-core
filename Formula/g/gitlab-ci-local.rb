class GitlabCiLocal < Formula
  desc "Run gitlab pipelines locally as shell executor or docker executor"
  homepage "https://github.com/firecow/gitlab-ci-local"
  url "https://registry.npmjs.org/gitlab-ci-local/-/gitlab-ci-local-4.55.0.tgz"
  sha256 "4acb80ab5e493d493ffca22217d9034005c50d46305d75d68101d8610fa425d6"
  license "MIT"
  head "https://github.com/firecow/gitlab-ci-local.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fcfdc08af79f07308a3e9f62749c5694c1d9abdd7e1c317d359e3af01453f921"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fcfdc08af79f07308a3e9f62749c5694c1d9abdd7e1c317d359e3af01453f921"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "fcfdc08af79f07308a3e9f62749c5694c1d9abdd7e1c317d359e3af01453f921"
    sha256 cellar: :any_skip_relocation, sonoma:        "be2cb0d722ce06e78f1ae42b1dcc2775a997346c90b2adc682a40b7170d25023"
    sha256 cellar: :any_skip_relocation, ventura:       "be2cb0d722ce06e78f1ae42b1dcc2775a997346c90b2adc682a40b7170d25023"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fcfdc08af79f07308a3e9f62749c5694c1d9abdd7e1c317d359e3af01453f921"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/".gitlab-ci.yml").write <<~YML
      ---
      stages:
        - build
        - tag
      variables:
        HELLO: world
      build:
        stage: build
        needs: []
        tags:
          - shared-docker
        script:
          - echo "HELLO"
      tag-docker-image:
        stage: tag
        needs: [ build ]
        tags:
          - shared-docker
        script:
          - echo $HELLO
    YML

    system "git", "init"
    system "git", "add", ".gitlab-ci.yml"
    system "git", "commit", "-m", "'some message'"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@test.com"
    rm ".git/config"

    (testpath/".git/config").write <<~EOS
      [core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
      [remote "origin"]
        url = git@github.com:firecow/gitlab-ci-local.git
        fetch = +refs/heads/*:refs/remotes/origin/*
      [branch "master"]
        remote = origin
        merge = refs/heads/master
    EOS

    assert_match(/name\s*?description\s*?stage\s*?when\s*?allow_failure\s*?needs\n/,
        shell_output("#{bin}/gitlab-ci-local --list"))
  end
end
