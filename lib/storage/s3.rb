require 'aws-sdk-s3'
require File.expand_path('../../storage', __FILE__)

class Storage::S3 < Storage

  attr_reader :region, :bucket, :bucket_host_alias, :prefix

  # accepts private, public-read, public-read-write,
  # authenticated-read, aws-exec-read, bucket-owner-read,
  # bucket-owner-full-control
  attr_reader :acl
    
  # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
  attr_reader :storage_class
  
  def initialize(configs={})
    super
    @region = configs[:region] ||= 'us-east-1'
    @bucket = configs[:bucket]
    @bucket_host_alias = configs[:bucket_host_alias]
    @prefix = configs[:prefix]
    @storage_class = configs[:storage_class] || 'STANDARD'
    @acl = configs[:acl] || 'private'
    
    @client = Aws::S3::Client.new({
      access_key_id: configs[:access_key_id],
      secret_access_key: configs[:secret_access_key],
      region: @region
    })
  end
  
  def object_for(key)
    Aws::S3::Object.new(@bucket, key, client: @client)
  end
  
  def local?
    false
  end
  
  def host
    @bucket_host_alias || "#{@bucket}.s3.amazonaws.com"
  end

  def url(key, expires_in: nil)
    object_for(destination(key)).presigned_url(:get, {
      expires_in: (expires_in || 3_600)
    })
  end

  def destination(key)
    [@prefix, partition(key)].compact.join('/').gsub(/^\//, '')
  end

  def exists?(key)
    object_for(destination(key)).exists?
  end

  def write(key, file, meta_info={})
    file = file.tempfile if file.class.name == "ActionDispatch::Http::UploadedFile"

    object_for(destination(key)).upload_file(file, {
      content_type: meta_info[:content_type],
      content_disposition: meta_info[:filename] ? "inline; filename=\"#{meta_info[:filename]}\"" : nil
      content_md5: meta_info[:md5],
      storage_class: @storage_class,
      acl: @acl
    })
  end
  
  def cp(key, to)
    object_for(destination(key)).download_file(to)
  end
  
  def read(key, &block)
    object_for(destination(key)).get({}, &block)
  end

  def delete(key)
    object_for(destination(key)).delete
  end
  
  def last_modified(key)
    object_for(destination(key)).last_modified
  end

  def mime_type(key)
    object_for(destination(key)).content_type
  end
  
end