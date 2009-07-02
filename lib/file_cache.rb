    def file_cache(key) 
      key = key.gsub(/\W/, '-')
      base = File.dirname(__FILE__) + "/../tmp/cache"
      FileUtils.mkdir_p(base)
      path = "#{base}/#{key}"
      if File.exists?(path)
        result = File.open(path) {|f| Marshal.load(f) }
      else
        result = yield
        File.open(path, "w") {|f| Marshal.dump(result, f) }
      end
      result
    end
