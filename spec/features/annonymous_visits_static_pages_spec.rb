require "feature_helper"

feature "Annonymous visits static pages" do
  before(:each) do
    create(:default_organization)
  end

  scenario "can visit the customization page" do
    page = create(:cms_page, title: "Pricing & Features")
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  scenario "can visit the overview page" do
    page = create(:cms_page, title: "Get DigitalLearn for Your Library")
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  scenario "can visit the portfolio page" do
    page = create(:cms_page, title: "See Our Work In Action")
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  describe "Header" do
    let!(:language) { create(:language) }
    let!(:spanish_lang) { create(:spanish_lang) }

    shared_examples "trainer link" do
      it "should exist on landing page" do
        visit root_path
        expect(page).to have_content("Tools and Resources for Trainers")
      end
    end

    context "under main domain" do
      before do
        switch_to_main_domain
      end
      include_examples "trainer link"
    end

    context "under sub domain" do
      let(:dpl) { create(:organization, subdomain: "dpl", name: "Denver Public Library") }
      before do
        switch_to_subdomain(dpl.subdomain)
      end
      include_examples "trainer link"
    end
  end
end
