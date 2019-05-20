describe TreeBuilderDefaultFilters do
  context 'TreeBuilderDefaultFilters' do
    before do
      role = MiqUserRole.find_by(:name => "EvmRole-operator")
      @group = FactoryBot.create(:miq_group, :miq_user_role => role, :description => "Default filters Group")
      login_as FactoryBot.create(:user, :userid => 'default_filters__wilma', :miq_groups => [@group])
      @filters = [MiqSearch.find_by(:description => "Platform / HyperV", :db => "Host")]
      @filters.push(MiqSearch.find_by(:description => "Environment / UAT", :db => "MiqTemplate"))
      @filters.push(MiqSearch.find_by(:description => "Environment / Prod", :db => "MiqTemplate"))
      @filters.push(FactoryBot.create(:miq_search,
                                       :name        => "default_Environment / Prod",
                                       :description => "Environment / Prod",
                                       :options     => nil,
                                       :db          => "Container",
                                       :search_type => "default",
                                       :search_key  => "_hidden_"))
      @filters.push(FactoryBot.create(:miq_search,
                                       :name        => "default_Environment / Prod",
                                       :description => "Environment / Prod",
                                       :options     => nil,
                                       :db          => "ContainerGroup",
                                       :search_type => "default",
                                       :search_key  => "_hidden_"))
      @filters.push(FactoryBot.create(:miq_search,
                                       :name        => "default_Environment / Prod",
                                       :description => "Environment / Prod",
                                       :options     => nil,
                                       :db          => "ContainerService",
                                       :search_type => "default",
                                       :search_key  => "_hidden_"))
      @filters.push(FactoryBot.create(:miq_search,
                                       :name        => "default_Environment / Prod",
                                       :description => "Environment / Prod",
                                       :options     => nil,
                                       :db          => "Storage",
                                       :search_type => "default",
                                       :search_key  => "_hidden_"))
      @filters.push(MiqSearch.find_by(:description => "Environment / Prod", :db => "Vm"))
      @sb = {:active_tree => :default_filters_tree}
      @default_filters_tree = TreeBuilderDefaultFilters.new(:df_tree, @sb, true, :data => @filters)
    end

    it 'is not lazy' do
      tree_options = @default_filters_tree.send(:tree_init_options)
      expect(tree_options[:lazy]).not_to be_truthy
    end

    it 'returns folders as root kids' do
      kids = @default_filters_tree.send(:x_get_tree_roots, false)
      kids.each do |kid|
        expect(kid[:icon]).to eq('pficon pficon-folder-close')
        expect(kid[:hideCheckbox]).to eq(true)
        expect(kid[:selectable]).to eq(false)
      end
    end

    it 'returns filter or folder as folder kids' do
      data = @default_filters_tree.send(:prepare_data, @filters)
      grandparents = @default_filters_tree.send(:x_get_tree_roots, false)
      grandparents.each do |grandparent|
        parents = @default_filters_tree.send(:x_get_tree_hash_kids, grandparent, false)
        parents.each do |parent|
          path = parent[:id].split('_')
          offsprings = data.fetch_path(path)
          if offsprings.kind_of?(Hash)
            kids = @default_filters_tree.send(:x_get_tree_hash_kids, parent, false)
            kids.each do |kid|
              expect(kid[:icon]).to eq('pficon pficon-folder-close')
              expect(kid[:hideCheckbox]).to eq(true)
              expect(kid[:selectable]).to eq(false)
              grandkids = @default_filters_tree.send(:x_get_tree_hash_kids, kid, false)
              grandkids.each_with_index do |grandkid, index|
                expect(grandkid[:icon]).to eq('fa fa-filter')
                expect(grandkid[:select]).to eq(offsprings[kid[:text]][index][:search_key] != "_hidden_")
              end
            end
          else
            kids = @default_filters_tree.send(:x_get_tree_hash_kids, parent, false)
            kids.each_with_index do |kid, index|
              expect(kid[:icon]).to eq('fa fa-filter')
              expect(kid[:select]).to eq(offsprings[index][:search_key] != "_hidden_")
            end
          end
        end
      end
    end
  end
end
