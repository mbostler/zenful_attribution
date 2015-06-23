class Axys::Report
  unless Rails.env.production?
    
    CACHE_BASEDIR = File.join Rails.root, "spec/assets/data"
    CACHE_DATEFMT = "%Y_%m_%d"
    # TODO: cache these reports!
    def run_with_caching( opts={} )
      if File.exists?( cached_filepath )
        self.attribs = YAML.load File.read( cached_filepath )
      else
        run_without_caching( opts )
        FileUtils.mkdir_p( File.dirname( cached_filepath ) )
        File.open( cached_filepath, "wb" ) { |f| f << self.attribs.to_yaml }
      end
    end
    alias_method :run_without_caching, :run!
    alias_method :run!, :run_with_caching
  
  
    def cached_filepath
      class_root = self.class.to_s.underscore
    
      filename_cleanse File.join( CACHE_BASEDIR, class_root, self.portfolio_name, cached_filename)
    end
  
    def cached_filename
      baseclass = self.class.to_s.split( '::' ).last.underscore
      filename = "#{baseclass}_#{self.portfolio_name}_#{self.start.strftime(CACHE_DATEFMT)}"
      if !!self.end
        filename << "_#{self.end.strftime(CACHE_DATEFMT)}"
      end
      filename << ".yml"
    end
  
    def filename_cleanse( txt )
      txt.delete( "+@&" )
    end
  end
end