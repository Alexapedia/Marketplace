import { Types } from 'mongoose';
import { relativizeUploads, uploadPath } from './upload-url';

const FILE = '817fdec8-fbef-4ee6-9943-4dc294abb565.png';

describe('uploadPath', () => {
  it('is a host-free path, so it works behind any store domain', () => {
    expect(uploadPath(FILE)).toBe(`/uploads/${FILE}`);
  });
});

describe('relativizeUploads', () => {
  it('strips the origin from a stored upload URL', () => {
    expect(relativizeUploads(`http://localhost:3000/uploads/${FILE}`)).toBe(
      `/uploads/${FILE}`,
    );
    expect(relativizeUploads(`https://api.example.com/uploads/${FILE}`)).toBe(
      `/uploads/${FILE}`,
    );
  });

  it('leaves other strings alone', () => {
    const external = 'https://cdn.example.com/uploads/photo.jpg';
    expect(relativizeUploads(external)).toBe(external);
    expect(relativizeUploads(`/uploads/${FILE}`)).toBe(`/uploads/${FILE}`);
    expect(relativizeUploads('Zezo Store')).toBe('Zezo Store');
  });

  it('rewrites nested objects and arrays', () => {
    const doc = {
      branding: { logo: `http://localhost:3000/uploads/${FILE}`, name: 'P' },
      images: [`http://localhost:3010/uploads/${FILE}`, 'https://x.io/a.png'],
    };
    expect(relativizeUploads(doc)).toEqual({
      branding: { logo: `/uploads/${FILE}`, name: 'P' },
      images: [`/uploads/${FILE}`, 'https://x.io/a.png'],
    });
  });

  it('returns the same reference when nothing changes', () => {
    const id = new Types.ObjectId();
    const date = new Date();
    const doc = { _id: id, at: date, tags: ['a'], meta: { n: 1 } };
    expect(relativizeUploads(doc)).toBe(doc);
  });

  it('keeps ObjectIds and dates intact inside a changed document', () => {
    const id = new Types.ObjectId();
    const date = new Date();
    const out = relativizeUploads({
      _id: id,
      at: date,
      image: `http://localhost:3000/uploads/${FILE}`,
    }) as Record<string, unknown>;
    expect(out._id).toBe(id);
    expect(out.at).toBe(date);
    expect(out.image).toBe(`/uploads/${FILE}`);
  });
});
