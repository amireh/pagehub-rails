def hypermedia_test(urls_proc)
  it 'should include hypermedia links' do
    output = subject.as_json.with_indifferent_access
    object = output[self.described_class.model_class.model_name.singular] || output

    realized_urls = instance_exec(&urls_proc)
    realized_urls.each_pair do |key, path|
      container = if key.to_s == 'href'
        object.should have_key(key)
        object
      else
        object['links'].should be_present
        object['links'].should have_key(key)
        object['links']
      end

      URI.parse(container[key]).path.should == path
    end
  end
end