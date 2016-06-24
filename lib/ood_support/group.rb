require 'etc'

module OodSupport
  # A helper object describing a Unix group's details
  class Group
    # The id of the group
    # @return [Fixnum] the group id
    attr_reader :id

    # The name of the group
    # @return [String] the group name
    attr_reader :name

    # @param group [Fixnum, #to_s] the group id or name
    def initialize(group)
      if group.is_a?(Fixnum)
        @id = group
        @name = Etc.getgrgid(group).name
      else
        @name = group
        @id = Etc.getgrnam(group.to_s).gid
      end
    end

    # Convert object to string using group name as string value
    # @return [String] the group name
    def to_s
      name
    end
  end
end
