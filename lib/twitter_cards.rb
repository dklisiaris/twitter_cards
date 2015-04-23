require "twitter_cards/version"
require 'nokogiri'
require 'restclient'
require 'hashie'

module TwitterCards
  
  # Fetch Twitter Cards data from the specified URI with a HTTP GET request.
  #
  # @param uri [String] the uri to fetch and extract cards from.
  # @param opts [Hash] options to customize functionality
  # @option :strict [Boolean] If set true, the object is retured only if the data are valid (i.e. not missing required attributes).
  # @return [Hashie Object, false] a TwitterCards::Object if there is data to be found or false otherwise.
  #
  def self.fetch(uri, opts = {})
    parse(RestClient.get(uri).body, opts)
  rescue RestClient::Exception, SocketError
    false
  end
  
  # Parses HTML and extracts Twitter Cards data.
  #
  # @param uri [String] the html text to parse and extract cards from.
  # @param opts [Hash] options to customize functionality
  # @option :strict [Boolean] If set true, the object is retured only if the data are valid (i.e. not missing required attributes) 
  # @return [Hashie Object, false] a TwitterCards::Object if there is data to be found or false otherwise.
  #  
  def self.parse(html, opts = {})
    doc = Nokogiri::HTML.parse(html)
    extract(doc, opts)
  end

  # Extracts Twitter Cards data from a parsed document.
  #
  # @param uri [Nokogiri::HTML::Document] the nokogiri parsed document extract cards from.
  # @param opts [Hash] options to customize functionality
  # @option :strict [Boolean] If set true, the object is retured only if the data are valid (i.e. not missing required attributes) 
  # @return [Hashie Object, false] a TwitterCards::Object if there is data to be found or false otherwise.
  #  
  def self.extract(doc, opts = {})
    opts[:strict] ||= false

    page = TwitterCards::Object.new
    doc.css('meta').each do |m|
      if m.attribute('name') and m.attribute('name').to_s.match(/^twitter:(.+)$/i)
        property = $1        
      elsif m.attribute('property') and m.attribute('property').to_s.match(/^twitter:(.+)$/i) 
        property = $1                       
      end

      if property
        property.gsub!(/[-:]/,'_')
        page[property] = m.attribute('content').to_s unless page[property]
      end
    end

    return false if page.keys.empty?
    return false unless page.valid? if opts[:strict]
    page
  end
  
  
  # The TwitterCards::Object is a Hash with method accessors for all detected Twitter Cards attributes.
  #  
  class Object < Hashie::Mash
    MANDATORY_ATTRIBUTES = {
      'summary'             => %w(card site title description),
      'summary_large_image' => %w(site title description),
      'photo'               => %w(card site image description),
      'gallery'             => %w(card site title image0 image1 image2 image3),
      'app'                 => %w(card site app:id:iphone app:id:ipad app:id:googleplay),
      'player'              => %w(card site title player player:width player:height image data1 label1 data2 label2),
      'product'             => %w(card site title description image data1 label1 data2 label2),
    }
    
    # The object type, summary if no card property found.
    def type
      self['card'] || 'summary'
    end

    # Quick way to fetch image
    def image
      self['image'] || self['image_src']
    end

    # Check if image property exists
    def image?
      image ? true : false
    end

    MANDATORY_ATTRIBUTES.keys.each do |card_type|
      define_method "#{card_type}?" do
        self.type == card_type
      end
    end

    
    # If the Twitter Cards information for this object doesn't contain
    # the mandatory attributes, this will be false.
    def valid?
      MANDATORY_ATTRIBUTES[type].each{|a| return false unless self[a]}
      true
    end
  end

end
