class PathInterpolator
  def self.path(request)
    request.params['vfs_path']
  end
end
