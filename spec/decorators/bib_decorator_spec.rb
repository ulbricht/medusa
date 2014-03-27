require 'spec_helper'

describe BibDecorator do
  let(:user) { FactoryGirl.create(:user) }
  before{ User.current = user }

  describe ".primary_picture" do
    after { bib.primary_picture(width: width, height: height) }
    let(:bib) { FactoryGirl.create(:bib).decorate }
    let(:width) { 250 }
    let(:height) { 250 }
    before { bib }
    context "attachment_files is null" do
      let(:attachment_file_1) { [] }
      it { expect(helper).not_to receive(:image_tag) }
    end
    context "attachment_files is not null" do
      let(:attachment_file_1) { FactoryGirl.create(:attachment_file, name: "att_1") }
      before { bib.attachment_files << attachment_file_1 }
      it { expect(helper).to receive(:image_tag).with(attachment_file_1.path, width: width, height: height) }
    end
  end

  describe ".name_with_id" do
  end

  describe ".to_html" do
    subject{ obj.to_html }
    let(:obj){FactoryGirl.create(:bib).decorate}

    context "author" do
      context "is blank" do
        before{obj.authors.clear}
        it{expect(subject).not_to include "Test_1 & Test_2"}
      end
      context "is not blank 1" do
        before do
          obj.authors.clear
          obj.authors << FactoryGirl.create(:author, name: "Test_1")
        end
        it{expect(subject).to include "Test_1"}
      end
      context "is not blank 2" do
        before do
          obj.authors.clear
          obj.authors << FactoryGirl.create(:author, name: "Test_1")
          obj.authors << FactoryGirl.create(:author, name: "Test_2")
        end
        it{expect(subject).to include "Test_1 & Test_2"}
      end
      context "is not blank 2" do
        before do
          obj.authors.clear
          obj.authors << FactoryGirl.create(:author, name: "Test_1")
          obj.authors << FactoryGirl.create(:author, name: "Test_2")
          obj.authors << FactoryGirl.create(:author, name: "Test_3")
        end
        it{expect(subject).to include "Test_1 et al."}
      end
    end
    context "year" do
      context "is blank" do
        before{obj.year = nil}
        it{expect(subject).not_to include "(2099)"}
      end
      context "is not blank" do
        before{obj.year = "2099"}
        it{expect(subject).to include "(2099)"}
      end
    end
    context "name" do
      context "is blank" do
        before{obj.name = nil}
        it{expect(subject).not_to include "medusa"}
      end
      context "is not blank" do
        before{obj.name = "medusa"}
        it{expect(subject).to include "medusa"}
      end
    end
    context "journal" do
      context "is blank" do
        before{obj.journal = nil}
        it{expect(subject).not_to include "<i>"}
      end
      context "is not blank" do
        before{obj.journal = "xxxx"}
        it{expect(subject).to include "<i>"}
      end
    end
    context "volume" do
      context "is blank" do
        before{obj.volume = nil}
        it{expect(subject).not_to include "<b>"}
      end
      context "is not blank" do
        before{obj.volume = "xxxx"}
        it{expect(subject).to include "<b>"}
      end
    end
    context "pages" do
      context "is blank" do
        before{obj.pages = nil}
        it{expect(subject).not_to include "9999"}
      end
      context "is not blank" do
        before{obj.pages = "9999"}
        it{expect(subject).to include "9999"}
      end
    end
    context "pages" do
      context "is blank" do
        before{obj.pages = nil}
        it{expect(subject).not_to include "9999"}
      end
      context "is not blank" do
        before{obj.pages = "9999"}
        it{expect(subject).to include "9999"}
      end
    end
  end

end
