require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class TimelogIndexPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users, :email_addresses, :members,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :time_entries

    ActiveRecord::FixtureSet.create_fixtures(
        File.dirname(__FILE__) + '/../fixtures/', [:roles, :member_roles])


    def setup
      page.driver.headers = { "Accept-Language" => "en-US" }

      visit '/projects/ecookbook/time_entries'
      assert_not_nil page
    end

    def teardown
      logout
    end

    def test_not_permitted_index_page
      login_with_no_permitted_user
      visit '/projects/ecookbook/time_entries'

      short_wait_time do
        assert_raises(Capybara::ElementNotFound) {
          assert find("Spent time", :visible => true)
        }
      end
    end

    def test_that_the_page_has_XLSX_link
      screenshot_and_save_page
      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

    def test_that_dialog_is_shown_when_the_link_is_clicked
      click_link("XLSX")

      assert find("div#xlsx-export-options", :visible => true)
    end

    def test_that_dialog_is_closed_when_cancel_is_clicked
      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Cancel")

      assert find("div#xlsx-export-options", :visible => false)
    end

    def test_that_export_with_selected_columns
      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_all_columns
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_all_projects
      visit '/time_entries'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_small_project
      login_with_user
      visit '/projects/ecookbook/time_entries'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_query
      page.select("User")
      page.select("John Smith")
      click_link("Apply")
      click_link("XLSX")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_all_projects_with_query
      visit '/time_entries'
      uncheck("Date")
      click_link("Apply")
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_set_status_filter_without_value
      login_with_admin
      visit '/projects/subproject1/time_entries?utf8=%E2%9C%93&set_filter=1&f%5B%5D=status_id&op%5Bstatus_id%5D=%3D'
      click_link("XLSX")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_sort
      login_with_admin

      visit '/projects/subproject1/time_entries?sort=project'
      assert_equal 200, page.status_code

      find(:xpath, "//a[@href='/projects/subproject1/time_entries.xlsx?sort=project']").click
      assert_equal 200, page.status_code
    end

  end
end