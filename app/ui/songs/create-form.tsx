'use client';

import { Album } from '@/app/lib/definitions';
import Link from 'next/link';
import {
  CheckIcon,
  ClockIcon,
  CurrencyDollarIcon,
  FolderIcon,
  LinkIcon,
  PencilIcon,
  PhotoIcon,
  UserCircleIcon,
} from '@heroicons/react/24/outline';
import { Button } from '@/app/ui/button';
import { createSong } from '@/app/lib/actions';
import { useFormState } from 'react-dom';

export default function Form(
  // {albums}: {albums: Album[]}
) {
  const initialState = { message: null, errors: {} };
  const [state, dispatch] = useFormState(createSong, initialState);

  return (
    <form action={dispatch}>
      <div className="rounded-md bg-gray-50 p-4 md:p-6">
        {/* Song Name */}
        <div className="mb-4">
          <label htmlFor="song_name" className="mb-2 block text-sm font-medium">
            Song Name
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="song_name"
                name="song_name"
                type="string"
                placeholder="Enter song name"
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              />
              <PencilIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
        </div>

        {/* Song Length */}
        <div className="mb-4">
          <label htmlFor="length" className="mb-2 block text-sm font-medium">
            Song Length
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="length"
                name="length"
                type="number"
                step="0"
                placeholder="Enter song length in seconds"
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              />
              <ClockIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
        </div>

        {/* Streaming Link */}
        <div className="mb-4">
          <label htmlFor="streaming_link" className="mb-2 block text-sm font-medium">
            Streaming Link (Optional)
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="streaming_link"
                name="streaming_link"
                type="string"
                placeholder="Enter song's host link"
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              />
              <LinkIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
        </div>

        {/* Song Image */}
        <div className="mb-4">
          <label htmlFor="cover_image_link" className="mb-2 block text-sm font-medium">
            Cover Image Link (Optional)
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="cover_image_link"
                name="cover_image_link"
                type="string"
                placeholder="Enter link to cover image"
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              />
              <PhotoIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
        </div>

        {/* Album */}
        {/* <div className="mb-4">
          <label htmlFor="album_id" className="mb-2 block text-sm font-medium">
            Add to Album (Optional)
          </label>
          <div className="relative">
            <select
              id="album_id"
              name="album_id"
              className="peer block w-full cursor-pointer rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              defaultValue=""
              aria-describedby="album-error"
            >
              <option value="" disabled>
                Select an album
              </option>
              {albums.map((album) => (
                <option key={album.album_id} value={album.album_id}>
                  {album.album_name}
                </option>
              ))}
            </select>
            <FolderIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500" />
          </div>
          <div id="album-error" aria-live="polite" aria-atomic="true">
            {state.errors?.album_id &&
              state.errors.album_id.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div> */}

      </div>
      <div className="mt-6 flex justify-end gap-4">
        <Link
          href="/dashboard/songs"
          className="flex h-10 items-center rounded-lg bg-gray-100 px-4 text-sm font-medium text-gray-600 transition-colors hover:bg-gray-200"
        >
          Cancel
        </Link>
        <Button type="submit">Publish Song</Button>
      </div>
    </form>
  );
}
