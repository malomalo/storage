class MultiStore
  
  def initialize(stores, default: nil)
    @stores = {}
    stores.map do |configs|
      if configs[0] == :filesystem
        configs[1] = {path: Rails.root.join('public/system/blobs').to_s}.merge(configs[1].symbolize_keys)
        configs[1][:path]&.gsub!(':rails', Rails.root.to_s)
      end
      @stores[configs[0].to_sym] = "StandardStorage::#{configs[0].capitalize}".constantize.new(configs[1].symbolize_keys)
    end
    
    if @stores.empty?
      @stores[:filesystem] = StandardStorage::Filesystem.new(path: Rails.root.join('public/system/blobs'))
    end
    
    @default_store = @stores[default.to_sym || :filesystem]
  end
  
  METHODS = [:url, :exists?, :write, :read, :delete, :last_modified, :mime_type, :cp, :copy_to_tempfile]
  def method_missing(m, *args, &block)
    if METHODS.include?(m)
      key = args.shift
      ss = (key.length == 40 ? @stores[:s3] : @stores[:b2]) || @default_store
      ss.send(m, key, *args, &block)
    else
      @default_store.send(m, *args, &block)
    end
  end
  
end
