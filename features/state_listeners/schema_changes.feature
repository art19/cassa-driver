# encoding: utf-8

Feature: schema change detection

  Cluster object allows registering state listeners. It then gurantees that
  they will be notifies on schema changes.

  Background:
    Given a running cassandra cluster
    And a file named "printing_listener.rb" with:
      """ruby
      class PrintingListener
        def initialize(io)
          @out = io
        end

        def schema_created(keyspace, table)
          @out.puts("Schema created keyspace=#{keyspace.inspect} table=#{table.inspect}")
        end

        def schema_updated(keyspace, table)
          @out.puts("Schema updated keyspace=#{keyspace.inspect} table=#{table.inspect}")
        end

        def schema_dropped(keyspace, table)
          @out.puts("Schema dropped keyspace=#{keyspace.inspect} table=#{table.inspect}")
        end
      end
      """
    And the following example running in the background:
      """ruby
      require 'printing_listener'
      require 'cql'

      listener = PrintingListener.new($stderr)
      cluster  = Cql.builder             \
                  .add_contact_point("127.0.0.1") \
                  .build

      cluster.register(listener)

      at_exit { cluster.close }

      sleep
      """

  Scenario: a new keyspace is created and then dropped
    When keyspace "new_keyspace" is created
    And keyspace "new_keyspace" is dropped
    Then background output should contain:
      """
      Schema created keyspace="new_keyspace" table=""
      Schema dropped keyspace="new_keyspace" table=""
      """