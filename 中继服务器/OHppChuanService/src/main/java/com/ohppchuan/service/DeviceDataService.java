package com.ohppchuan.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class DeviceDataService {
    // 使用线程安全的ConcurrentHashMap存储数据
    private final Map<String, Map<String, Object>> dataStore = new ConcurrentHashMap<>();

    public void saveDeviceData(String imei, Map<String, Object> data) {
        dataStore.put(imei, data);
    }

    public Map<String, Object> getDeviceData(String imei) {
        Map<String, Object> data = dataStore.get(imei);
        if (data == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Device data not found");
        }
        return data;
    }
}
