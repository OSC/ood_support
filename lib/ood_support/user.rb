require 'forwardable'
require 'etc'

module OodSupport
  # A helper object used to query information about a system user from the
  # local host
  class User
    extend Forwardable

    # @!method name
    #   The user name
    #   @return [String] the user name
    # @!method uid
    #   The user's id
    #   @return [Integer] the user id
    # @!method gecos
    #   The user's real name
    #   @return [String] the real name
    # @!method dir
    #   The user's home directory
    #   @return [String] the home path
    # @!method shell
    #   The user's shell
    #   @return [String] the shell
    delegate [:name, :uid, :gecos, :dir, :shell] => :@passwd

    alias_method :id, :uid

    # List of all groups that user belongs to
    # @return [Array<String>] list of groups user is in
    attr_reader :groups

    # @param user [Fixnum, #to_s] user id or name
    def initialize(user = Process.user)
      @passwd = user.is_a?(Fixnum) ? Etc.getpwuid(user) : Etc.getpwnam(user.to_s)
      @groups = get_groups
    end

    # Determine whether user is part of specified group
    # @param group [Group] group to check
    # @return [Boolean] whether user is in group
    def in_group?(group)
      groups.include? Group.new(group)
    end

    # Provide primary group of user
    # @return [Group] primary group of user
    def group
      groups.first
    end

    # The comparison operator for sorting values
    # @param another_user [User] user to compare against
    # @return [Fixnum] how users compare
    def <=>(another_user)
      name <=> another_user.name
    end

    # Boolean evaluation of object equality
    # @param another_user [User] user to compare against
    # @return [Boolean] whether user names are same
    def ==(another_user)
      id == another_user.id
    end

    # Boolean evaluation of object equality
    # @param another_user [User] user to compare against
    # @return [Boolean] whether user names are same
    def eql?(another_user)
      self == another_user
    end

    # Generates a hash value for this object
    # @return [Fixnum] hash value of object
    def hash
      id.hash
    end

    # Convert object to string using user name as string value
    # @return [String] the user name
    def to_s
      name
    end

    private
      # Use `id` to get list of groups as the /etc/group file can give
      # erroneous results
      def get_groups
        `id -G #{name}`.split(' ').map {|g| Group.new(g.to_i)}
      end
  end
end
