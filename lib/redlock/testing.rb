module Redlock
  class Client
    attr_writer :testing_mode

    alias_method :try_lock_instances_without_testing, :try_lock_instances

    def try_lock_instances(resource, ttl)
      if @testing_mode == :bypass
        {
          validity: ttl,
          resource: resource,
          value: SecureRandom.uuid
        }
      elsif @testing_mode == :fail
        false
      else
        try_lock_instances_without_testing resource, ttl
      end
    end

    alias_method :unlock_without_testing, :unlock

    def unlock(lock_info)
      unlock_without_testing lock_info unless @testing_mode == :bypass
    end

    class RedisInstance
      def load_scripts
        if @redis.respond_to?(:script)
          @unlock_script_sha = @redis.script(:load, UNLOCK_SCRIPT)
        end
      end
    end
  end
end
