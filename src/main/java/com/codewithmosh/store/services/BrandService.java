package com.codewithmosh.store.services;

import com.codewithmosh.store.dtos.BrandRequest;
import com.codewithmosh.store.dtos.BrandResponse;
import com.codewithmosh.store.entities.Brand;
import com.codewithmosh.store.mappers.BrandMapper;
import com.codewithmosh.store.repositories.BrandRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


import java.util.List;
import java.util.NoSuchElementException;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class BrandService {
    private final BrandRepository brandRepository;
    private final BrandMapper brandMapper;

    public List<BrandResponse> getAll(){
        return brandRepository.findAll()
                .stream()
                .map(brandMapper::toResponse)
                .toList();
    }

    public BrandResponse getById(Long id){
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Brand with id=" + id + " not found")
                );
        return brandMapper.toResponse(brand);
    }

    public BrandResponse create(BrandRequest request){
        if(brandRepository.existsByName(request.getName())){
            throw new IllegalArgumentException("Brand with name='" + request.getName() +"' already exists");
        }
        if(brandRepository.existsBySlug(request.getSlug())){
            throw new IllegalArgumentException("Brand with slug='" + request.getSlug() +"' already exists");
        }
        Brand brand = brandMapper.toEntity(request);
        Brand saved = brandRepository.save(brand);
        return brandMapper.toResponse(saved);
    }

    public BrandResponse update(Long id, BrandRequest request){
        Brand existing = brandRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Brand with id=" + id + " not found"));

        if(brandRepository.existsByNameAndIdNot(request.getName(), id)){
            throw new IllegalArgumentException("Brand with name='\" + request.getName() + \"' already exists");
        }

        if (brandRepository.existsBySlugAndIdNot(request.getSlug(), id)) {
            throw new IllegalArgumentException(
                    "Brand with slug='" + request.getSlug() + "' already exists");
        }
        Brand updated = brandMapper.updateEntity(request, existing);
        Brand saved = brandRepository.save(updated);
        return brandMapper.toResponse(saved);
    }

    public void delete(Long id) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException(
                        "Brand with id=" + id + " not found"));
        brandRepository.delete(brand);
    }
}
