module FastHaml
  class Generator < Temple::Generators::ArrayBuffer
    def return_buffer
      %Q|#{buffer}.shift if #{buffer}[0] == "\\n"; #{buffer} = #{buffer}.join|
    end
  end
end
