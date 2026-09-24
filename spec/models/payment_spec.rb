# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "scopes and class methods" do
    describe ".in_last_days" do
      it "returns payments created within the given days" do
        user = create(:user, confirmed_at: Time.current)
        p1 = create(:payment, user: user, created_at: 5.days.ago)
        create(:payment, user: user, created_at: 31.days.ago)

        result = described_class.in_last_days(days: 30)

        expect(result).to include(p1)
        expect(result.count).to eq(1)
      end
    end
  end
end
