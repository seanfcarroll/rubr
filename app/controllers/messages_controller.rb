class MessagesController < ApplicationController

  def new
    @message = Message.new
  end

  def index
    @threads = current_account.matches
  end

  def chain
    puts params.inspect
    @message = Message.new
    messages_with = Account.where(id: params[:id]).first
    if messages_with
      @messages = current_account.messages_with messages_with

      # Count the messages as read
      @messages.where(read: false, receiver_id: current_account.id).update_all(read: true, read_at: Time.now)
    else
      #TODO what do here
      @messages = []
    end
  end

  # API call
  def get_chain
    begin
      messages_with = Account.where(id: params[:id]).first
      if messages_with
        #TODO: this needs to be formatted into a nicer date for the message page
        messages = current_account.messages_with messages_with
      else
        #TODO what do here
        messages = []
      end

      respond_to do |format|
        format.json { render json: messages.to_a }
      end

    rescue => e
      puts "Error getting messages"
      puts e.inspect
      render :status => 500
    end
  end

  # API call
  # TODO: rework this part
  def create
    message_params = params[:message]
    status = 200
    send_to = Account.where(id: message_params[:receiver_id]).first
    message_body = message_params[:body].sanitize

    if send_to
      #if current_account.is_matched? send_to
      if true
        message = Message.new(
          sender_id: current_account.id,
          receiver_id: message_params[:receiver_id],
          body: message_body,
          sent_at: Time.now
        )
        if message.save
          puts "Message sent"
        else
          status = 727
        end
      else
        puts "Not matched but trying to send message"
      end
    else
      status = 727
    end

    return redirect_to "/messages/#{message_params[:receiver_id]}/"

  end

end
