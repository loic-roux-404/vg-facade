source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in vg-facade.gemspec
gemspec

group :development do
  gem "vagrant", git: "https://github.com/hashicorp/vagrant.git"
end

group :plugins do
  gem "my-vagrant-plugin", path: "."
end
