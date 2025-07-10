package com.ohppchuan.service;

import com.ohppchuan.service.DeviceDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.Map;

@RestController
@RequestMapping("/api/devices")
@CrossOrigin(origins = "*") // 允许所有跨域请求
public class DeviceController {

    private final DeviceDataService dataService;

    @Autowired
    public DeviceController(DeviceDataService dataService) {
        this.dataService = dataService;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> saveDeviceData(@RequestBody Map<String, Object> payload) {
        String IME;
        try{
            Map<String, Object> header=(Map<String, Object>) ((Map<String, Object>)payload.get("notify_data")).get("header");
            IME=header.get("node_id").toString();
            dataService.saveDeviceData(IME, payload);
        }catch (Exception e) {
            System.out.println("[WARNING]:Bad POST.");
            return ResponseEntity.badRequest().build();
        }

        System.out.println("[INFO]:Add a New Message to IME(="+IME+") Successfully.");
        return ResponseEntity.ok(Collections.singletonMap("status", "success"));
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getDeviceData(
            @RequestParam(value = "imei", required = true) String imei) {
        try {
            Map<String, Object> data = dataService.getDeviceData(imei);
            System.out.println("[INFO]:GET Successfully.");
            return ResponseEntity.ok(data);
        } catch (Exception e) {
            System.out.println("[WARNING]:Bad GET for 404.");
            return ResponseEntity.notFound().build();
        }
    }
}
