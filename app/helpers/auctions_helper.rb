module AuctionsHelper
  PHASE_LABELS = {
    draft: "ร่าง", upcoming: "เร็ว ๆ นี้", live: "กำลังประมูล",
    closing: "กำลังปิด", ended: "ปิดประมูลแล้ว", cancelled: "ยกเลิก"
  }.freeze

  def baht(amount)
    "฿#{number_with_delimiter(amount.to_d.round(2).to_s.sub(/\.0+\z/, ""))}"
  end

  # Bidders see each other only as "som***" to keep identities private.
  def mask_name(user)
    name = user.username
    "#{name[0, 3]}***"
  end

  def phase_badge(auction)
    phase = auction.phase
    tag.span(PHASE_LABELS[phase], class: "phase phase--#{phase}")
  end

  def thai_datetime(time)
    time&.in_time_zone&.strftime("%d/%m/%Y %H:%M")
  end

  def auction_cover(auction, **options)
    if auction.photos.attached?
      image_tag rails_blob_path(auction.photos.first, disposition: "inline"), alt: auction.title, loading: "lazy", **options
    else
      tag.div("ไม่มีรูป", class: "cover-placeholder")
    end
  end
end
