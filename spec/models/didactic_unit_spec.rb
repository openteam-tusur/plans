# == Schema Information
#
# Table name: didactic_units
#
#  id         :integer          not null, primary key
#  gos_id     :integer
#  discipline :string(255)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe DidacticUnit do
  let(:didactic_unit) { DidacticUnit.new :content => content }
  describe '#lecture_themes' do
    subject { didactic_unit.lecture_themes([2, 1]) }
    describe 'should split items' do
      describe 'by paragraph' do
        let(:content) { "item1\n \nitem2" }
        it { should == [["Item1"], ["Item2"]] }
      end

      describe 'by . inside paragraphs' do
        let(:content) { "Item1. Item2\n Item3." }
        it { should == [["Item1", "Item2"], ["Item3"]] }
        context 'sentences with abbreviated verbs must not be splitted' do
          let(:content) { "Item1. item2\n Item3." }
          it { should == [["Item1. item2"], ["Item3"]] }
        end
      end

      describe 'by ; inside sentences' do
        let(:content) { "item1: item2; item3. Item4; item5." }
        it { should == [["Item1: item2", "Item3", "Item4"], ["Item5"]] }
      end
    end
  end
end
