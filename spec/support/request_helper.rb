DEFAULT_CONTENT_PRESENTER = lambda do |block|
  result = {}

  block.content.each do |k, v|
    result[k.to_s] = v
  end

  result
end