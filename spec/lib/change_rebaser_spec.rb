# frozen_string_literal: true

RSpec.describe DiscourseSuggestedEdits::ChangeRebaser do
  let(:change_class) { Struct.new(:position, :start_offset, :before_text, :after_text) }
  let(:old_raw) { "aaa\nbbb\nccc\nddd\n" }

  def change(before, after, position: 0, raw: old_raw)
    change_class.new(position, raw.index(before), before, after)
  end

  def rebase(applied, others)
    new_raw = DiscourseSuggestedEdits::ChangeApplier.call(raw: old_raw, changes: applied)
    described_class.call(applied:, changes: others, new_raw:)
  end

  it "shifts changes located after the applied one" do
    result = rebase([change("bbb\n", "bbbbbbbb\n")], [change("ddd\n", "DDD\n")])

    expect(result.raw).to eq("aaa\nbbbbbbbb\nccc\nDDD\n")
    expect(result.changes.map(&:start_offset)).to eq([17])
  end

  it "keeps changes located before the applied one in place" do
    result = rebase([change("ccc\n", "")], [change("aaa\n", "AAA\n")])

    expect(result.raw).to eq("AAA\nbbb\nddd\n")
    expect(result.changes.first.start_offset).to eq(0)
  end

  it "allows adjacent changes" do
    result = rebase([change("bbb\n", "B\n")], [change("ccc\n", "C\n")])

    expect(result.raw).to eq("aaa\nB\nC\nddd\n")
  end

  it "returns nil when the same lines are changed" do
    expect(rebase([change("bbb\n", "B1\n")], [change("bbb\n", "B2\n")])).to be_nil
  end

  it "returns nil when ranges partially overlap" do
    applied = change_class.new(0, 4, "bbb\nccc\n", "X\n")
    other = change("ccc\nddd\n", "Y\n")

    expect(rebase([applied], [other])).to be_nil
  end

  it "returns nil for two insertions at the same point" do
    applied = change_class.new(0, 4, "", "one\n")
    other = change_class.new(0, 4, "", "two\n")

    expect(rebase([applied], [other])).to be_nil
  end

  it "handles several applied and several rebased changes" do
    applied = [change("aaa\n", "A\n", position: 0), change("ccc\n", "CCCCCC\n", position: 1)]
    others = [change("bbb\n", "B\n", position: 0), change("ddd\n", "D\n", position: 1)]

    expect(rebase(applied, others).raw).to eq("A\nB\nCCCCCC\nD\n")
  end

  it "returns nil when the new raw no longer matches the base text" do
    result =
      described_class.call(
        applied: [change("aaa\n", "A\n")],
        changes: [change("ddd\n", "D\n")],
        new_raw: "completely different\n",
      )

    expect(result).to be_nil
  end
end
