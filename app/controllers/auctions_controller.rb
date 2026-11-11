class AuctionsController < ApplicationController
  layout "site"
  allow_unauthenticated_access only: %i[ index show calendar ]
  before_action :resume_session, only: %i[ index show calendar ]
  require_permission :create_auctions, only: %i[ new create ]
  before_action :set_auction, only: %i[ show edit update ]
  before_action :require_editable, only: %i[ edit update ]

  TABS = %w[ live upcoming ended mine ].freeze
  PER_PAGE = 24

  def index
    @tab = TABS.include?(params[:tab]) ? params[:tab] : "live"
    if @tab == "mine" && !authenticated?
      return request_authentication
    end

    @query = params[:q].to_s.strip
    scope = case @tab
    when "live" then Auction.live.order(:ends_at)
    when "upcoming" then Auction.upcoming.order(:starts_at)
    when "ended" then Auction.finished.order(ends_at: :desc)
    when "mine" then Current.user.auctions.where.not(status: "cancelled").order(created_at: :desc)
    end
    scope = scope.where("title ILIKE ?", "%#{Auction.sanitize_sql_like(@query)}%") if @query.present?
    @page = [ params[:page].to_i, 1 ].max
    @total = scope.count
    @auctions = scope.includes(:seller).with_attached_photos.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end

  def calendar
    @month = (Date.strptime(params[:month].to_s, "%Y-%m") rescue Date.current).beginning_of_month
    range = @month.beginning_of_week(:sunday).beginning_of_day..@month.end_of_month.end_of_week(:sunday).end_of_day
    @auctions_by_day = Auction.visible.where(starts_at: range)
      .order(:starts_at).group_by { it.starts_at.to_date }
  end

  def show
    visible = @auction.published? || @auction.ended? || @auction.seller == Current.user || can?(:manage_auctions)
    raise ActiveRecord::RecordNotFound unless visible
    @bids = @auction.bids.includes(:user).limit(20)
    @chat_messages = @auction.chat_messages.includes(:user).order(:id).last(50)
    @bid = Bid.new(amount: @auction.minimum_bid)
  end

  def new
    start = 1.hour.from_now.change(min: 0)
    @auction = Current.user.auctions.build(starts_at: start, ends_at: start + 1.day)
  end

  def create
    @auction = Current.user.auctions.build(auction_params)
    @auction.status = params[:publish] ? "published" : "draft"
    if @auction.save
      redirect_to @auction, notice: @auction.published? ? "เปิดประมูลแล้ว" : "บันทึกร่างแล้ว"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @auction.assign_attributes(auction_params.except(:photos))
    @auction.photos.attach(auction_params[:photos]) if auction_params[:photos].present?
    @auction.photos.where(id: params[:remove_photo_ids]).each(&:purge_later) if params[:remove_photo_ids].present?
    @auction.status = "published" if params[:publish] && @auction.draft?
    if @auction.save
      redirect_to @auction, notice: "บันทึกแล้ว"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_auction
      @auction = Auction.find(params[:id])
    end

    def require_editable
      redirect_to @auction, alert: "แก้ไขรายการนี้ไม่ได้แล้ว" unless @auction.editable_by?(Current.user)
    end

    def auction_params
      params.expect(auction: [ :title, :description, :starting_price, :min_increment, :starts_at, :ends_at, photos: [] ]).tap do |p|
        p[:photos] = Array(p[:photos]).compact_blank if p.key?(:photos)
      end
    end
end
