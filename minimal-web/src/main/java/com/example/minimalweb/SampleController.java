package com.example.minimalweb;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.List;

import static java.util.stream.Collectors.toList;

@Controller
public class SampleController {

    private static final int ARRAY_SIZE = 1_000_000;

    @RequestMapping(value = "/health", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("up");
    }

    @RequestMapping(value = "/test", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> test() {
        int[] array = new int[ARRAY_SIZE];
        for (int i = 0; i < array.length; ++i) {
            array[i] = i * i;
        }

        return ResponseEntity.ok("finished");
    }
}
