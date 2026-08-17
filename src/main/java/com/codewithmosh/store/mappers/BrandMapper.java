package com.codewithmosh.store.mappers;

import com.codewithmosh.store.dtos.BrandRequest;
import com.codewithmosh.store.dtos.BrandResponse;
import com.codewithmosh.store.entities.Brand;
import org.springframework.stereotype.Component;

@Component
public class BrandMapper {
    public Brand toEntity(BrandRequest request){
        Brand brand = new Brand();
        brand.setName(request.getName());
        brand.setSlug(request.getSlug());
        return brand;
    }

    public BrandResponse toResponse(Brand brand){
        return new BrandResponse(brand.getId(), brand.getName(), brand.getSlug());
    }

    public Brand updateEntity(BrandRequest request, Brand brand){
        brand.setName(request.getName());
        brand.setSlug(request.getSlug());
        return brand;
    }
}
