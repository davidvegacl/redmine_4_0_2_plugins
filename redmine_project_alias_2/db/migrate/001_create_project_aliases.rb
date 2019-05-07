class CreateProjectAliases < ActiveRecord::Migration[5.0]

    def self.up
        unless table_exists? :project_aliases
            create_table :project_aliases do |t|
                t.column :project_id, :integer, :null => false
                t.column :alias,      :string,  :null => false
            end
            add_index :project_aliases, [ :alias ], :unique => true, :name => :project_alias
        end
    end

    def self.down
        drop_table :project_aliases
    end

end
