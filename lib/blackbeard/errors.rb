module Blackbeard
  class GroupNotInMetric < StandardError; end
  class StorableMasterKeyUndefined < StandardError; end
  class StorableNotFound < StandardError; end
  class StorableDuplicateKey < StandardError; end
  class StorableNotSaved < StandardError; end
  class UserIdNotDivisable < StandardError; end
end
