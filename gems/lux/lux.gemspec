Gem::Specification.new do |spec|
  spec.name          = "lux"
  spec.version       = "1.0.0"
  spec.authors       = ["Ahmad Amireh"]
  spec.email         = ["ahmad@amireh.net"]
  spec.summary       = "Model locking for Rails."

  spec.files         = Dir.glob("{lib,spec}/**/*")
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails", ">= 4.1", "< 6"
end
