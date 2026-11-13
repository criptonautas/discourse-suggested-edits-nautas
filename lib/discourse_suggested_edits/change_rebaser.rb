# frozen_string_literal: true

module DiscourseSuggestedEdits
  # Moves a pending suggestion's changes onto a post that just had other changes applied.
  # Returns nil when any change overlaps an applied one or no longer matches the new raw.
  class ChangeRebaser
    Result = Struct.new(:changes, :raw)
    Shifted = Struct.new(:position, :start_offset, :before_text, :after_text)

    def self.call(applied:, changes:, new_raw:)
      new(applied:, changes:, new_raw:).call
    end

    def initialize(applied:, changes:, new_raw:)
      @applied = applied
      @changes = changes.sort_by(&:position)
      @new_raw = new_raw
    end

    def call
      return if @changes.any? { |change| @applied.any? { |a| overlaps?(a, change) } }

      shifted =
        @changes.map do |change|
          shift = @applied.sum { |a| end_of(a) <= change.start_offset ? growth(a) : 0 }
          Shifted.new(
            change.position,
            change.start_offset + shift,
            change.before_text,
            change.after_text,
          )
        end

      Result.new(shifted, ChangeApplier.call(raw: @new_raw, changes: shifted))
    rescue ChangeApplier::MismatchError
      nil
    end

    private

    def end_of(change) = change.start_offset + change.before_text.length

    def growth(change) = change.after_text.length - change.before_text.length

    # Adjacent changes do not overlap; two insertions at the same point do (order is ambiguous).
    def overlaps?(a, b)
      return a.start_offset == b.start_offset if a.before_text.empty? && b.before_text.empty?

      a.start_offset < end_of(b) && b.start_offset < end_of(a)
    end
  end
end
