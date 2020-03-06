require_relative 'test_helper'

describe Hotel::Controller do
  describe "initialize" do
    let(:hotel_controller) {Hotel::Controller.new}

    it "is an instance of Controller" do
      expect(hotel_controller).must_be_kind_of Hotel::Controller
    end
  end

  describe "find_available_rooms" do
    let(:hotel_controller) {Hotel::Controller.new}
    before do 
      @start_date = Date.new(2020, 1, 1)
      @end_date = Date.new(2020, 1, 2)
      @booked_range = Hotel::DateRange.new(@start_date, @end_date)
      @test_range = Hotel::DateRange.new(@start_date+5, @end_date+5)
    end

    it "returns an array" do
      expect(hotel_controller.find_available_rooms(@booked_range)).must_be_kind_of Array
    end

    it "returns an array containing (a) room_id(s)" do
      hotel_controller.rooms[11].create_room_reservation(@booked_range)

      expect(hotel_controller.find_available_rooms(@booked_range)[0]).must_be_kind_of Integer
      expect(hotel_controller.find_available_rooms(@booked_range).length).must_equal 19
    end

    it "returns an array of the correct number of Rooms that have availability" do
      hotel_controller.rooms[11].create_room_reservation(@booked_range)
      hotel_controller.rooms[12].create_room_reservation(@booked_range)

      expect(hotel_controller.find_available_rooms(@booked_range).length).must_equal 18
    end

    it "returns only the correct room ids of the Rooms that have availability" do
      # add rez to multiple rooms only if id is evenly divisible by 3
      hotel_controller.rooms.each do |room|
        if room.room_id % 3 == 0
          room.create_room_reservation(@booked_range)
        end
      end

      expect(hotel_controller.find_available_rooms(@booked_range)[0]).must_equal 1
      expect(hotel_controller.find_available_rooms(@booked_range)[1]).must_equal 2
      expect(hotel_controller.find_available_rooms(@booked_range)[2]).must_equal 4
      expect(hotel_controller.find_available_rooms(@booked_range)[4]).must_equal 7
    end
  end

  describe "reserve_with_range" do
    let(:hotel_controller) {Hotel::Controller.new}
    before do
      @start_date = Date.new(2020, 1, 1)
      @end_date = Date.new(2020, 1, 2)
      @room_id = 1
      @booked_range = Hotel::DateRange.new(@start_date, @end_date)
      @new_reservation = Hotel::Reservation.new(@input_range,@room_id)
    end

    it "returns false if the input range cannot be accommodated in any room" do
      hotel_controller.rooms.each do |room|
        room.create_room_reservation(@booked_range)
      end

      expect(hotel_controller.reserve_with_range(@booked_range)).must_equal false
    end

    it "returns the room_id of the first room that can accommodate the input range" do
      # Room 1 is booked during range
      hotel_controller.rooms[0].create_room_reservation(@booked_range)

      expect(hotel_controller.reserve_with_range(@booked_range)).must_equal 2
    end

    it "ensures the new reservation was created and added to correct room's rez list" do
      hotel_controller.reserve_with_range(@booked_range)

      # rez should have been made in the first room, therefore check rez list of room[0]
      expect(hotel_controller.rooms[0].rez_list.length).must_equal 1
      expect(hotel_controller.rooms[0].rez_list[0].date_range).must_equal @booked_range
    end


      # it "creates a new reservation" do
    #   expect(hotel_controller.reserve_with_range(@input_range)).must_be_kind_of Hotel::Reservation
    # end

    # it "adds the new reservation to the correct room's rez list" do
    #   other_date_range = Hotel::DateRange.new(@start_date+1, @end_date+1)
    #   other_reservation = Hotel::Reservation.new(other_date_range,3)

    #   expect(hotel_controller.all_reservations.length).must_equal 0
    #   # add the first new reservation
    #   hotel_controller.reserve_with_range(@input_range)
    #   expect(hotel_controller.all_reservations.length).must_equal 1

    #   # add another reservation
    #   hotel_controller.reserve_with_range(other_date_range)
    #   expect(hotel_controller.all_reservations.length).must_equal 2
    # end

  end

  # describe "find_by_date" do
  #   let(:hotel_controller) {Hotel::Controller.new}
  #   before do
  #     @start_date = Date.new(2020, 1, 1)
  #     @end_date = Date.new(2020, 1, 2)
  #     @room_id = 5
  #     @date_range_1 = Hotel::DateRange.new(@start_date, @end_date)
  #     @reservation_1 = Hotel::Reservation.new(@date_range_1,@room_id)
  #     hotel_controller.reserve_with_range(@date_range_1)
      
  #     @date_range_2 = Hotel::DateRange.new(@start_date+1, @end_date+1)
  #     @reservation_2 = Hotel::Reservation.new(@date_range_2,3)
  #     hotel_controller.reserve_with_range(@date_range_2)
  #   end

  #   it "returns an array" do
  #     expect(hotel_controller.find_by_date(@date_range_1)).must_be_kind_of Array
  #   end

  #   it "finds the reservation(s) with the matching date" do
  #     result_1 = hotel_controller.find_by_date(@date_range_1)[0]
  #     expect(result_1.date_range).must_equal @date_range_1

  #     result_2 = hotel_controller.find_by_date(@date_range_2)[0]
  #     expect(result_2.date_range).must_equal @date_range_2
  #   end

  #   it "returns the correct number of Reservations that match a given date_range" do
  #     #Arrange/ Act
  #     result_1 = hotel_controller.find_by_date(@date_range_1)[0]
  #     expect(result_1.date_range).must_equal @date_range_1

  #     result_2 = hotel_controller.find_by_date(@date_range_2)[0]
  #     expect(result_2.date_range).must_equal @date_range_2

  #     # Assert
  #     hotel_controller.reserve_with_range(@date_range_2)
  #     result_3 = hotel_controller.find_by_date(@date_range_2)
  #     expect(result_3.length).must_equal 2
  #   end

  #   it "returns empty array if no date_range matches are found" do
  #     expect(hotel_controller.find_by_date(@date_range_3)).must_be_empty
  #   end
  # end

# Private methods test
  describe "create_rooms" do
    let(:hotel_controller) {Hotel::Controller.new}

    it "creates an Array of 20 Room objects" do
      expect(hotel_controller.rooms).must_be_kind_of Array
      expect(hotel_controller.rooms.length).must_equal 20
      hotel_controller.rooms.each do |room|
        expect(room).must_be_kind_of Hotel::Room
      end
    end

    it "creates the correct ids for each room" do
      expect(hotel_controller.rooms[0].room_id).must_equal 1
      expect(hotel_controller.rooms[19].room_id).must_equal 20
      expect(hotel_controller.rooms[20]).must_be_nil
    end

  end
end