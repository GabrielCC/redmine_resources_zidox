class DivisionsController < BaseController
  def index
    @divisions = Division.all

    respond_to do |format|
      format.html
      format.json { render json: @divisions }
    end
  end

  def show
    @division = Division.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @division }
    end
  end

  def new
    @division = Division.new

    respond_to do |format|
      format.html
      format.json { render json: @division }
    end
  end

  def edit
    @division = Division.find(params[:id])
  end

  def create
    @division = Division.new(params[:division])

    respond_to do |format|
      if @division.save
        format.html { redirect_to @division, notice: 'Division was successfully created.' }
        format.json { render json: @division, status: :created, location: @division }
      else
        format.html { render action: "new" }
        format.json { render json: @division.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @division = Division.find(params[:id])

    respond_to do |format|
      if @division.update_attributes(params[:division])
        format.html { redirect_to @division, notice: 'Division was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @division.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @division = Division.find(params[:id])
    @division.destroy

    respond_to do |format|
      format.html { redirect_to divisions_url }
      format.json { head :no_content }
    end
  end
end
