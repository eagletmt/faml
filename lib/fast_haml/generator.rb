module FastHaml
  class Generator < Temple::Generators::ArrayBuffer
    def return_buffer
      "#{buffer}.shift unless #{buffer}.empty?; #{buffer} = #{buffer}.join"
    end
  end
end
