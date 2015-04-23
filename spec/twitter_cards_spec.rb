#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe TwitterCards do
  let(:bbc)     { File.open(File.dirname(__FILE__) + '/test_data/bbc.html').read      }
  let(:gallery) { File.open(File.dirname(__FILE__) + '/test_data/gallery.html').read  }
  let(:multiple){ File.open(File.dirname(__FILE__) + '/test_data/multiple.html').read }
  let(:invalid) { File.open(File.dirname(__FILE__) + '/test_data/invalid.html').read  }

  describe '#parse' do
    it 'returns false if there isnt any twitter cards data' do
      expect(TwitterCards.parse("")).to eq false      
    end
    
    it 'returns a TwitterCards::Object if there is any twitter cards data' do
      expect(TwitterCards.parse(bbc)).to be_kind_of(TwitterCards::Object)
    end

    it 'returns a TwitterCards::Object if there is any twitter cards data even invalid' do
      expect(TwitterCards.parse(invalid)).to be_kind_of(TwitterCards::Object)
    end    
    
    context 'with strict mode enabled' do      

      it 'returns false if required attributes are missing' do
        expect(TwitterCards.parse(invalid, :strict => true)).to eq false
      end

      it 'returns a TwitterCards::Object if data is valid' do
        expect(TwitterCards.parse(gallery, :strict => true)).to be_kind_of(TwitterCards::Object)
      end
    end    
  end

  describe '#fetch' do 
    it 'fetches from the specified URL' do
      stub_request(:get, 'http://www.bbc.com/news/technology-32422193').to_return(:body => bbc)
      expect(TwitterCards.fetch('http://www.bbc.com/news/technology-32422193').title).to eq 'Google launches Project Fi mobile phone network - BBC News'
      expect(WebMock).to have_requested(:get, 'http://www.bbc.com/news/technology-32422193')
    end
    
    it 'catches errors' do
      stub_request(:get, 'http://example.com').to_return(:status => 404)
      expect(TwitterCards.fetch('http://example.com')).to eq false
      RestClient.should_receive(:get).with('http://example.com').and_raise(SocketError)
      expect(TwitterCards.fetch('http://example.com')).to eq false
    end
  end

  describe '#extract' do
    let(:bbc_doc) {Nokogiri::HTML.parse(bbc)}
    let(:invalid_doc) {Nokogiri::HTML.parse(invalid)}    

    it 'returns false if there isnt any twitter cards data' do
      expect(TwitterCards.extract(Nokogiri::HTML.parse(""))).to eq false      
    end
    
    it 'returns a TwitterCards::Object if there is any twitter cards data' do
      expect(TwitterCards.extract(bbc_doc)).to be_kind_of(TwitterCards::Object)
    end

    it 'returns a TwitterCards::Object if there is any twitter cards data even invalid' do
      expect(TwitterCards.extract(invalid_doc)).to be_kind_of(TwitterCards::Object)
    end    
    
    context 'with strict mode enabled' do      

      it 'returns false if required attributes are missing' do
        expect(TwitterCards.extract(invalid_doc, :strict => true)).to eq false
      end

      it 'returns a TwitterCards::Object if data is valid' do
        expect(TwitterCards.extract(bbc_doc, :strict => true)).to be_kind_of(TwitterCards::Object)
      end
    end 
  end


  it 'has a version number' do
    expect(TwitterCards::VERSION).not_to be nil
  end

end

describe TwitterCards::Object do

end
