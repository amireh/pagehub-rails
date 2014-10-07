# Convenience for calling @resource = Fixtures[:resource].build({})
def fixture(type, *params)
  resource = Fixtures[type].build(*params)
  instance_variable_set("@#{type}", resource)
  resource
end

def invalid!(resource)
  if resource.is_a?(ActiveModel::Errors)
    resource.to_a.should_not == []
    return resource
  end

  resource.error_messages.should_not == []
  resource.valid?.should be_false
  yield(resource) if block_given?
  resource
end

def valid!(resource)
  if resource.is_a?(ActiveModel::Errors)
    resource.to_a.should == []
    return resource
  end

  is_valid = resource.valid?
  resource.error_messages.should == []
  is_valid.should be_true
  yield(resource) if block_given?
  resource
end

def json_fixture(path)
  json = JSON.parse File.read File.join(Rails.root, 'spec', 'fixtures', path)
  json.is_a?(Hash) ? json.with_indifferent_access : json
end

def file_fixture(path, read=false)
  filepath = File.join(Rails.root, 'spec', 'fixtures', path)

  if read
    return File.read(filepath)
  end

  filepath
end