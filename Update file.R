name: Render R Markdown

on:
  push:
  branches: [ main ]

jobs:
  render:
  runs-on: ubuntu-latest
steps:
  - uses: actions/checkout@v2
- uses: r-lib/actions/setup-r@v2
- uses: r-lib/actions/setup-pandoc@v2
- name: Install required packages (if any)
run: |
  Rscript -e 'install.packages(c("rmarkdown", "YOUR_OTHER_PACKAGE"))'  # Replace "YOUR_OTHER_PACKAGE" with your actual packages
- name: Render Rmarkdown
run: |
  Rscript -e 'rmarkdown::render("path/to/your/rmd_file.Rmd")'
- name: Commit changes
run: |
  git config --local user.name "GitHub Actions"
git config --local user.email "github-actions[bot]@users.noreply.github.com"
git add "path/to/your/output_file.html"  # Replace with your actual output filename
git commit -m "Automatic render of R Markdown document" || echo "No changes to commit"
- name: Push changes
uses: actions/checkout@v2
with:
  push: true
# Replace with your personal access token if necessary (see security note below)
github-token: ${{ secrets.GITHUB_TOKEN }}
