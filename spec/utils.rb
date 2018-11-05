module Utils
  TestRepoResult = Struct.new(:repository, keyword_init: true)
  TestUserResult = Struct.new(:user, keyword_init: true)
  TestStubResult = Struct.new(:stub, keyword_init: true)
end
