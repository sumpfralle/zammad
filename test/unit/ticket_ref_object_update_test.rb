# encoding: utf-8
require 'test_helper'

class TicketRefObjectTouchTest < ActiveSupport::TestCase

  # create base
  groups = Group.where( :name => 'Users' )
  roles  = Role.where( :name => 'Agent' )
  agent1 = User.create_or_update(
    :login         => 'ticket-ref-object-update-agent1@example.com',
    :firstname     => 'Notification',
    :lastname      => 'Agent1',
    :email         => 'ticket-ref-object-update-agent1@example.com',
    :password      => 'agentpw',
    :active        => true,
    :roles         => roles,
    :groups        => groups,
    :updated_at    => '2015-02-05 16:37:00',
    :updated_by_id => 1,
    :created_by_id => 1,
  )
  roles  = Role.where( :name => 'Customer' )
  organization1 = Organization.create_if_not_exists(
    :name          => 'Ref Object Update Org',
    :updated_at    => '2015-02-05 16:37:00',
    :updated_by_id => 1,
    :created_by_id => 1,
  )
  customer1 = User.create_or_update(
    :login           => 'ticket-ref-object-update-customer1@example.com',
    :firstname       => 'Notification',
    :lastname        => 'Agent1',
    :email           => 'ticket-ref-object-update-customer1@example.com',
    :password        => 'customerpw',
    :active          => true,
    :organization_id => organization1.id,
    :roles           => roles,
    :updated_at      => '2015-02-05 16:37:00',
    :updated_by_id   => 1,
    :created_by_id   => 1,
  )
  customer2 = User.create_or_update(
    :login           => 'ticket-ref-object-update-customer2@example.com',
    :firstname       => 'Notification',
    :lastname        => 'Agent2',
    :email           => 'ticket-ref-object-update-customer2@example.com',
    :password        => 'customerpw',
    :active          => true,
    :organization_id => nil,
    :roles           => roles,
    :updated_at      => '2015-02-05 16:37:00',
    :updated_by_id   => 1,
    :created_by_id   => 1,
  )

  test 'a - check if customer and organization has been updated' do

    ticket = Ticket.create(
      :title         => "some title1\n äöüß",
      :group         => Group.lookup( :name => 'Users'),
      :customer_id   => customer1.id,
      :owner_id      => agent1.id,
      :state         => Ticket::State.lookup( :name => 'new' ),
      :priority      => Ticket::Priority.lookup( :name => '2 normal' ),
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    assert( ticket, "ticket created" )
    assert_equal( ticket.customer.id, customer1.id  )
    assert_equal( ticket.organization.id, organization1.id  )

    # check if customer and organization has been touched
    customer1 = User.find(customer1.id)
    if customer1.updated_at > 2.second.ago
      assert( true, "customer1.updated_at has been updated" )
    else
      assert( false, "customer1.updated_at has not been updated" )
    end

    organization1 = Organization.find(organization1.id)
    if organization1.updated_at > 2.second.ago
      assert( true, "organization1.updated_at has been updated" )
    else
      assert( false, "organization1.updated_at has not been updated" )
    end

    sleep 4

    delete = ticket.destroy
    assert( delete, "ticket destroy" )

    # check if customer and organization has been touched
    customer1 = User.find(customer1.id)
    if customer1.updated_at > 2.second.ago
      assert( true, "customer1.updated_at has been updated" )
    else
      assert( false, "customer1.updated_at has not been updated" )
    end

    organization1 = Organization.find(organization1.id)
    if organization1.updated_at > 2.second.ago
      assert( true, "organization1.updated_at has been updated" )
    else
      assert( false, "organization1.updated_at has not been updated" )
    end
  end

  test 'b - check if customer (not organization) has been updated' do

    sleep 3
    ticket = Ticket.create(
      :title         => "some title2\n äöüß",
      :group         => Group.lookup( :name => 'Users'),
      :customer_id   => customer2.id,
      :owner_id      => agent1.id,
      :state         => Ticket::State.lookup( :name => 'new' ),
      :priority      => Ticket::Priority.lookup( :name => '2 normal' ),
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    assert( ticket, "ticket created" )
    assert_equal( ticket.customer.id, customer2.id  )
    assert_equal( ticket.organization, nil  )

    # check if customer and organization has been touched
    customer2 = User.find(customer2.id)
    if customer2.updated_at > 2.second.ago
      assert( true, "customer2.updated_at has been updated" )
    else
      assert( false, "customer2.updated_at has not been updated" )
    end

    organization1 = Organization.find(organization1.id)
    if organization1.updated_at > 2.second.ago
      assert( false, "organization1.updated_at has been updated" )
    else
      assert( true, "organization1.updated_at has not been updated" )
    end

    sleep 3

    delete = ticket.destroy
    assert( delete, "ticket destroy" )

    # check if customer and organization has been touched
    customer2 = User.find(customer2.id)
    if customer2.updated_at > 2.second.ago
      assert( true, "customer2.updated_at has been updated" )
    else
      assert( false, "customer2.updated_at has not been updated" )
    end

    organization1 = Organization.find(organization1.id)
    if organization1.updated_at > 2.second.ago
      assert( false, "organization1.updated_at has been updated" )
    else
      assert( true, "organization1.updated_at has not been updated" )
    end

  end
end