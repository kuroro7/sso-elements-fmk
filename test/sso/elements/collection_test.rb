# frozen_string_literal: true

require_relative "../../test_helper"

class SSO::Elements::CollectionTest < Minitest::Test
  CFG_FILE = 'lib/sso/elements/configs/PW_1.0.2_v150.cfg'
  ELE_FILE = 'lib/sso/elements/samples/elements.data'
  EL2_FILE = 'lib/sso/elements/samples/elements.data.copy'

  def teardown
    File.delete(EL2_FILE) if File.exist?(EL2_FILE)
  end
  def test_load_and_save_all
    assert_path_exists CFG_FILE
    assert_path_exists ELE_FILE

    collection = SSO::Elements::Collection.new
    collection.load_config!(CFG_FILE)
    loaded = collection.load_elements!(ELE_FILE)
    assert_equal loaded, true

    saved = collection.save! EL2_FILE
    assert_equal saved, true

    assert_path_exists EL2_FILE

    bin_src = File.binread(ELE_FILE)
    bin_dst = File.binread(EL2_FILE)

    assert_equal bin_src, bin_dst, "Binary data is not equal"
  end

  def test_without_providing_config
    assert_path_exists CFG_FILE
    assert_path_exists ELE_FILE

    collection = SSO::Elements::Collection.new
    loaded = collection.load_elements!(ELE_FILE)
    assert_equal loaded, true

    saved = collection.save! EL2_FILE
    assert_equal saved, true

    assert_path_exists EL2_FILE

    bin_src = File.binread(ELE_FILE)
    bin_dst = File.binread(EL2_FILE)

    assert_equal bin_src, bin_dst, "Binary data is not equal"
  end

  def test_cfg_number_load
    collection = SSO::Elements::Collection.new
    loaded = collection.load_config!(150)
    assert_equal loaded, true
  end

  def test_create_npc
    collection = SSO::Elements::Collection.new
    collection.load_config!(CFG_FILE)
    loaded = collection.load_elements!(ELE_FILE)
    assert_equal loaded, true

    npc_essence = collection.table('NpcEssence')
    refute_nil npc_essence

    some_random_npc = npc_essence.find_element_by_id 4850
    refute_nil some_random_npc

    npc = some_random_npc.clone
    refute_nil npc

    npc.id = 120031
    npc.name = 'Donovan'
    npc.item_exchange_service = 0
    npc.file_model = 2023
    npc.file_icon = 4713
    npc.name_prof_prefix = 'Just someone'

    npc_essence.add_element(npc)

    collection.save! EL2_FILE

    collection = SSO::Elements::Collection.new
    collection.load_config!(CFG_FILE)
    loaded = collection.load_elements!(EL2_FILE)
    assert_equal loaded, true

    npc_essence = collection.table('NpcEssence')
    refute_nil npc_essence

    npc2 = npc_essence.find_element_by_id 120031
    refute_nil npc2

    assert_equal npc.id, npc2.id
    assert_equal npc.name, npc2.name
    assert_equal npc.item_exchange_service, npc2.item_exchange_service
    assert_equal npc.file_model, npc2.file_model
    assert_equal npc.file_icon, npc2.file_icon
    assert_equal npc.name_prof_prefix, npc2.name_prof_prefix
  end
end
