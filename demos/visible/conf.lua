function love.conf(t)
  t.releases = {
    title = "Visibility Demo",
    loveVersion = "11.0",
    version = "1.0.0",
    author = "Felecarp",
    description = "Demonstration of visibility polygon function",
    excludeFileList = {
      "*.git",
      "*.md",
      "*.zip",
      "*.love",
    },
    releaseDirectory = "build",
  }
  t.window.title = t.releases.title
  t.window.width = 512
  t.window.height = 512
end
